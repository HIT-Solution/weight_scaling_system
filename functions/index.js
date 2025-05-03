
async function sendEmail(to, subject, message) {
  try {
    await transporter.sendMail({
      from: "hasandiu1122@gmail.com",
      to,
      subject,
      text: message,
    });
    console.log(`✅ Email sent to ${to} | Subject: ${subject}`);
  } catch (err) {
    console.error(`❌ Email send failed for ${to}:`, err);
  }
}
