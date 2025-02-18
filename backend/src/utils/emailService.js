import nodemailer from "nodemailer"

const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
        user: process.env.EMAIL_USER, 
        pass: process.env.EMAIL_PASS, 
    },
});

export const sendEmail = async (email,subject,text) => {
    try {
        const mailOptions = {
            from: `"Hostel Management" <${process.env.EMAIL_USER}>`,
            to,
            subject,
            text,
        };

        await transporter.sendMail(mailOptions);
        console.log("Password change email sent to", email);
    } catch (error) {
        console.error("Error sending password change email:", error);
    }
};