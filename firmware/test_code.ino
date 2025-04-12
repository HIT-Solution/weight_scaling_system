#include <WiFi.h>                 // For ESP32 (use ESP8266WiFi.h for ESP8266)
#include <WebServer.h>            // For synchronous web server
#include <Firebase_ESP_Client.h>  // Firebase ESP Client library
#include <ArduinoJson.h>
#include <addons/TokenHelper.h>  // For token generation and handling
#include <time.h>

// Firebase credentials
#define FIREBASE_PROJECT_ID "weight-scale-371f5"
#define FIREBASE_API_KEY "AIzaSyCF0JbaR9ABlMPJcfvnqrFEWaINXVkh3F8"

WebServer server(80);
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// ESP Access Point SSID
const char* esp_ssid = "WeightScale";
String wifiSSID, wifiPassword, userId, wifiMac, rfidTag, currentWeight;
bool credentialsReceived = false;
bool isConnectedToWifi = false;
unsigned long previousMillis = 0;     // Timer for updates
const unsigned long interval = 1000;  // Interval in ms (1 second)

// Firebase config struct
struct FirebaseConfigData {
  const char* api_key = FIREBASE_API_KEY;
  const char* database_url = "https://weight-scale-371f5-default-rtdb.firebaseio.com";
  const char* user_email = "weightscale@gmail.com";
  const char* user_password = "123456";
} firebaseConfigData;

// Function Prototypes
void sendDeviceStatus();
void configureFirebase();
void serverCreate();
void getCredentials();
void connectToWiFi();
unsigned long getCurrentTimeMillis();
void setupTime();

void configureFirebase() {
  wifiMac = WiFi.macAddress();
  config.api_key = firebaseConfigData.api_key;
  config.database_url = firebaseConfigData.database_url;
  auth.user.email = firebaseConfigData.user_email;
  auth.user.password = firebaseConfigData.user_password;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void connectToWLAN() {
  // Configure Firebase
  configureFirebase();

  // Set time for timestamps
  configTime(0, 0, "pool.ntp.org", "time.nist.gov");

  // Send device details
  sendDeviceStatus();
  isConnectedToWifi = true;

  Serial.println("Device connected via Ethernet and registered successfully.");
}

void connectToWiFi() {
  Serial.println("Connecting to Wi-Fi...");
  WiFi.mode(WIFI_STA);
  WiFi.begin(wifiSSID.c_str(), wifiPassword.c_str());

  int retryCount = 0;
  const int maxRetries = 5;

  while (WiFi.status() != WL_CONNECTED && retryCount < maxRetries) {
    delay(2000);
    Serial.print("Attempting to connect... ");
    Serial.println(retryCount + 1);
    retryCount++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("Connected to Wi-Fi.");
    configureFirebase();
    configTime(0, 0, "pool.ntp.org", "time.nist.gov");
    // Send data with locationId first
    sendDeviceStatus();
    isConnectedToWifi = true;
  } else {
    isConnectedToWifi = false;
    Serial.println("Wi-Fi connection failed. Restarting...");
    ESP.restart();
  }
}

String getCurrentTime() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Failed to obtain time");
    return "";
  }
  char buf[20];
  strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%S", &timeinfo);
  return String(buf);
}

void sendDeviceStatus() {
  String wifiMac = WiFi.macAddress();
  // Set device path
  String devicePath = "users/" + userId + "/scales/" + wifiMac;

  // Create the overall device JSON object
  FirebaseJson deviceJson;
  deviceJson.set("rfidTag", rfidTag);
  deviceJson.set("currentWeight", currentWeight);
  deviceJson.set("sentTime", getCurrentTime());

  // Send data to Firebase
  if (Firebase.RTDB.setJSON(&fbdo, devicePath.c_str(), &deviceJson)) {
    Serial.println("Device status sent successfully.");
  } else {
    Serial.print("Error sending device status: ");
    Serial.println(fbdo.errorReason());
  }
}

void setup() {
  Serial.begin(115200);
  //getCredentials();
  //if(wifiSSID.isEmpty()){ serverCreate();} 
  test();
}
void serverCreate() {
  WiFi.softAP(esp_ssid);
  Serial.println("ESP Access Point started.");

  server.on("/connect", []() {
    StaticJsonDocument<256> jsonDoc;
    if (deserializeJson(jsonDoc, server.arg("plain")) == DeserializationError::Ok) {
      wifiSSID = jsonDoc["ssid"] | "";
      wifiPassword = jsonDoc["password"] | "";
      userId = jsonDoc["userId"] | "";

      if (!wifiSSID.isEmpty() && !wifiPassword.isEmpty() && !userId.isEmpty()) {
        credentialsReceived = true;
        server.send(200, "application/json", "{\"status\": \"received\"}");
        connectToWiFi();
        // listenToOutputValues();  // Start listening after Wi-Fi connection
      } else if (!userId.isEmpty()) {
        credentialsReceived = true;
        server.send(200, "application/json", "{\"status\": \"received\"}");
        connectToWLAN();
      } else {
        server.send(400, "application/json", "{\"error\": \"Missing parameters\"}");
      }
    } else {
      server.send(400, "application/json", "{\"error\": \"Invalid JSON\"}");
    }
  });
  server.begin();
}
void test() {
  wifiSSID = "HIT";
  wifiPassword = "Hasansit@007";
  userId = "user1001";
  rfidTag = "tag1";
  currentWeight = "10";

  connectToWiFi();
}
void loop() {
  server.handleClient();
  unsigned long currentMillis = millis();

  if (isConnectedToWifi && WiFi.status() == WL_CONNECTED && currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    sendDeviceStatus();
    delay(5000);
  }
}
