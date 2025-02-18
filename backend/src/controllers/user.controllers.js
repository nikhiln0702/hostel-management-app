import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { User } from "../models/user.models.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import bcrypt from "bcryptjs";
import { sendEmail } from "../utils/emailService.js";

//testing 

const sampleUsers = [
    {
        username: "john_doe",
        email: "john.doe@example.com",
        password: "password123"
    },
    {
        username: "jane_smith",
        email: "jane.smith@example.com",
        password: "securepassword456"
    },
    {
        username: "alex_jones",
        email: "alex.jones@example.com",
        password: "alexpass789"
    }
];





//Login a student
const loginStudent = asyncHandler(async (req, res, next) => {
    //Get email and password 
    const { email, password, rememberMe } = req.body;


    if (!email || !password) {
        return next(new ApiError(400, "Please provide email and password"));
    }

    //Finding the user using email
    const user = await User.findOne({ where: { email } });




    //Invalid credentials
    if (!user) {
        return next(new ApiError(401, "Invalid credentials"));
    }

    if (!(await user.isValidPassword(password))) {
        return next(new ApiError(401, "Invalid credentials"));
    }

    //Generate token
    const accessToken = user.generateAccessToken();
    const refreshToken = user.generateRefreshToken(rememberMe);
    user.refreshToken = refreshToken;

    //Save Token to db
    await user.save();
    return res.status(200)
        .json(new ApiResponse(200, "Student logged in successfully", { email, password, accessToken, refreshToken }));
})

//Login a warden
const loginWarden = asyncHandler(async (req, res, next) => {
    //Get email and password 
    const { email, password } = req.body;
    User(email, password);


    if (!email || !password) {
        return next(new ApiError(400, "Please provide email and password"));
    }

    //Finding user using email
    const user = await User.findOne({ where: { email } });





    if (!user) {
        return next(new ApiError(401, "Invalid credentials"));
    }
    if (await user.isValidPassword(password)) {
        return next(new ApiError(401, "Invalid password"));
    }

    //Generate token
    const accessToken = user.generateAccessToken();
    const refreshToken = user.generateRefreshToken();

    //Save token to db
    user.refreshToken = refreshToken;

    await user.save();


    return res.status(200)
        .json(new ApiResponse(200, "Warden logged in successfully", { email, password, accessToken, refreshToken }));
})

//Logout
const logout = asyncHandler(async (req, res, next) => {
    try {
        // Get the User from verifyJWT
        const user = req.user
        if (!user) {
            return next(new ApiError(404, "User not found"))
        }
        // Set User's refresh token to null and save to db
        user.refreshToken = null
        await user.save()

        return res.status(200)
            .json(new ApiResponse(200, "Logout Successfull"))
    }
    catch (error) {
        return res.status(500)
            .json(new ApiResponse(500, "Logout Failed"))
    }
})

//Change Password
const changePassword = asyncHandler(async (req, res, next) => {

    const { oldPassword, newPassword } = req.body
    if (!oldPassword || !newPassword) {
        return next(new ApiError(400, "Both fields are required"))
    }
    const userID = req.user.id

    const user = await User.findByPk(userID)

    if (!user) {
        return next(new ApiError(404, "User Not Found"))
    }
    const isValidPassword = await user.isValidPassword(oldPassword)

    if (!isValidPassword) {
        return next(new ApiError(400, "Incorrect Password"))
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10)

    user.password = hashedPassword
    await user.save()

    //To be Tested
    const text = `
    <h3>Hello ${user.username},</h3>
    <p>Your password has been successfully changed.</p>
    <p>If this wasn't you, please contact support immediately.</p>
    <br>
    <p>Regards,<br>Hostel Management Team</p>
`
    await sendEmail(user.email, "Password Changed", text)


    return res.status(200)
        .json(new ApiResponse(200, "Password Changed Successfully"))


})

//Forgot Password
const forgotPassword = asyncHandler(async (req, res, next) => {
    const { email } = req.body
    if (!email) {
        return next(new ApiError(400, "Email is required"))
    }
    const user = await User.findOne({ where: { email } })
    if (!user) {
        return next(new ApiError(404, "User Not Found"))
    }
    req.user = user

    //Generate OTP
    const otp = crypto.randomInt(100000, 999999).toString();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000);

    // Save OTP to DB
    await user.update({ otp, otpExpires });

    try {
        // Send OTP via email
        await sendEmail(email, "Password Reset OTP", `Your OTP is: ${otp}`);
    }
    catch (error) {
        return next(new ApiError(500, "Error sending OTP email"));  // Error handling for email sending
    }

    return res.status(200)
        .json(new ApiResponse(200, "OTP sent to your email"))

})

//reset password
const resetPassword = asyncHandler(async (req, res, next) => {
    const { newPassword } = req.body
    if (!newPassword) {
        return next(new ApiError(400, "Password field empty"))
    }
    const user = req.user
    if (!user) {
        return next(new ApiError(404, "User not found"))
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10)

    user.password = hashedPassword
    await user.save()

    //To be Tested
    const text = `
    <h3>Hello ${user.username},</h3>
    <p>Your password has been reset.</p>
    <p>If this wasn't you, please contact support immediately.</p>
    <br>
    <p>Regards,<br>Hostel Management Team</p>
`
    try {
        await sendEmail(user.email, "Password Reset", text)
    }
    catch (error) {
        return next(new ApiError(500, "Email was not send"))
    }

    return res.status(200)
        .json(new ApiResponse(200, "Password Reset"))
})

//verify otp
const verifyOTP=asyncHandler(async(req,res,next)=>{
    const {otp}=req.body
    if(!otp)
    {
        return next(new ApiError(400,"OTP Field Empty"))
    }
    const user=req.user

    if(!user)
    {
        return next(new ApiError(404,"User Not Found"))
    }
    if(user.otp != otp || new Date() > user.otpExpires)
    {
        return next(new ApiError(400,"Invalid OTP"))
    }
    

    // OTP is valid, reset it
    await user.update({ otp: null, otpExpires: null });

    return res.status(200)
    .json(new ApiResponse(200,"OTP Verified"))
})

//refesh Tokens
const refreshToken = asyncHandler(async (req, res, next) => {
    const { token } = req.body;
    if (!token) {
        return next(new ApiError(401, "Access Denied"));
    }
    let decoded;
    try 
    {
        decoded = jwt.verify(token, process.env.REFRESH_TOKEN_SECRET);
        console.log("Token verified", decoded);
    } 
    catch (err) 
    {
        return next(new ApiError(401, "Invalid or Expired Token"));
    }
    const user=await user.findByPk(decoded.id)
    if(!user)
    {
        return next(new ApiError(404,"User not found"))
    }
    const accessToken=user.generateAccessToken()

    return res.status(200)
    .json(new ApiResponse(200,"token refreshed",{accessToken}))

})

export { loginStudent, loginWarden, logout, changePassword, forgotPassword, resetPassword, verifyOTP , refreshToken };