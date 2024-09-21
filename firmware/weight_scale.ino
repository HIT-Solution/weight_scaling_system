// #include <BLEDevice.h>
// #include <BLEServer.h>
// #include <BLEUtils.h>
// #include <BLE2902.h>
// #include <ArduinoJson.h>  // Include the ArduinoJson library

// BLECharacteristic *txCharacteristic;  // For transmitting counter value
// BLECharacteristic *rxCharacteristic;  // For receiving data from Flutter
// bool deviceConnected = false;
// const int LED = 2;             // Define the LED pin number here
// #define MAX_STRING_LENGTH 100  // Change this to the appropriate length to hold your string
// char txString[MAX_STRING_LENGTH];

// // See the following for generating UUIDs:
// // https://www.uuidgenerator.net/
// #define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"  // UART service UUID
// #define CHARACTERISTIC_UUID_RX "beb5483e-36e1-4688-b7f5-ea07361b26a8"
// #define CHARACTERISTIC_UUID_TX "beb5483e-36e1-4688-b7f5-ea07361b26a9"
// float txValue = 0;
// // char txString[8];

// class MyServerCallbacks : public BLEServerCallbacks {
//   void onConnect(BLEServer *pServer) {
//     deviceConnected = true;
//     Serial.println("Device connected.");
//   }

//   void onDisconnect(BLEServer *pServer) {
//     deviceConnected = false;
//     Serial.println("Device disconnected.");
//     pServer->getAdvertising()->start(); // Restart advertising after disconnection
//   }
// };

// class MyCallbacks : public BLECharacteristicCallbacks {
//   void onWrite(BLECharacteristic *pCharacteristic) {
//     std::string rxValue = pCharacteristic->getValue();

//     if (rxValue.length() > 0) {
//       Serial.println("*********");
//       Serial.print("Received Value: ");
//       //Serial.print(rxValue.length());

//       for (int i = 0; i < rxValue.length(); i++) {
//         Serial.print(rxValue[i]);
//       }

//       Serial.println();
//       Serial.println("*********");

//       // Process the received data here
//       // For example, you can toggle an LED based on the received value
//       if (rxValue[0] == '1') {
//         Serial.println("Turning ON!");
//         digitalWrite(LED, HIGH);
//       } else if (rxValue[0] == '0') {
//         Serial.println("Turning OFF!");
//         digitalWrite(LED, LOW);
//       }
//     }
//   }
// };

// String createJsonString() {
//   // Create a DynamicJsonDocument
//   DynamicJsonDocument jsonDocument(256);  // Adjust the buffer size accordingly based on your data
//   jsonDocument["product1"] = 5;
//   jsonDocument["product2"] = 20;
//   jsonDocument["product3"] = 3;
//   jsonDocument["product4"] = 2;

//   // Serialize the JSON object to a String
//   String jsonString;
//   serializeJson(jsonDocument, jsonString);

//   return jsonString;
// }

// void setup() {
//   Serial.begin(115200);
//   pinMode(LED, OUTPUT);

//   // Create the BLE Device
//   BLEDevice::init("weight_scale");  // Give it a name
//   BLEDevice::setMTU(517);
//   // Create the BLE Server
//   BLEServer *pServer = BLEDevice::createServer();
//   pServer->setCallbacks(new MyServerCallbacks());

//   // Create the BLE Service
//   BLEService *pService = pServer->createService(SERVICE_UUID);

//   // Create a BLE Characteristic for receiving data
//   rxCharacteristic = pService->createCharacteristic(
//     CHARACTERISTIC_UUID_RX,
//     BLECharacteristic::PROPERTY_WRITE);
//   rxCharacteristic->setCallbacks(new MyCallbacks());

//   // Create a BLE Characteristic for transmitting data (counter value)
//   txCharacteristic = pService->createCharacteristic(
//     CHARACTERISTIC_UUID_TX,
//     BLECharacteristic::PROPERTY_NOTIFY);
//   txCharacteristic->addDescriptor(new BLE2902());  // Add CCCD descriptor for notifications

//   // Start the service
//   pService->start();

//   // Start advertising
//   pServer->getAdvertising()->start();
//   Serial.println("Waiting for a client connection...");
// }

// void loop() {

//   String jsonStr = createJsonString();
//   //String jsonStr = "1";

//   // Now, send the JSON string via BLE notification
//   txCharacteristic->setValue((uint8_t *)jsonStr.c_str(), jsonStr.length());
//   txCharacteristic->notify();

//   Serial.print("*** Sent JSON: ");
//   Serial.print(jsonStr);
//   Serial.println(" ***");

//   delay(5000);
// }
