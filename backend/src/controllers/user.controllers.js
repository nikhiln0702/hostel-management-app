import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { User } from "../models/user.models.js";
import { LeaveRegister } from "../models/leaveregister.models.js";
import { Complaint } from "../models/complaints.models.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { sendEmail } from "../utils/emailService.js";
import crypto from "crypto";

//testing 

const sampleUsers = [
    {
        username: "john_doe",
        email: "john.doe@example.com",
        password: "password12345"
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

// async function insertUsers() {
//     try {
//       // Loop through sampleUsers and hash passwords before creating them
//       const usersWithHashedPasswords = await Promise.all(sampleUsers.map(async (user) => {
//         const hashedPassword = await bcrypt.hash(user.password, 10);
//         return { ...user, password: hashedPassword };
//       }));

//       // Perform bulkCreate with validation enabled
//       await User.bulkCreate(usersWithHashedPasswords, { validate: true });
//       console.log('Users have been inserted successfully');
//     } catch (error) {
//       console.error('Error inserting users:', error);
//     }
//   }


//   insertUsers();




//Login a student
export const loginStudent = asyncHandler(async (req, res, next) => {
    //Get email and password 
    const { email, password, rememberMe } = req.body;


    if (!email || !password) {
        return next(new ApiError(400, "Please provide email and password"));
    }
    //Finding the user using email
    const user = await User.findOne({ where: { email } });




    //Invalid credentials
    if (!user) {
        return res.status(400)
        .json(new ApiResponse(400, "User not found"))
    }

    if (!(await user.isValidPassword(password))) {
        return res.status(400)
        .json(new ApiResponse(401, "Invalid credentials"));
    }

    //Generate token
    const accessToken = user.generateAccessToken();
    const refreshToken = user.generateRefreshToken(rememberMe);
    user.refreshToken = refreshToken;

    //Save Token to db
    await user.save();
    return res.status(200)
        .json(new ApiResponse(200, "Student logged in successfully", { email, password, accessToken, refreshToken,rememberMe}));
})

//Login a warden
export const loginWarden = asyncHandler(async (req, res, next) => {
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
    User.refreshToken = refreshToken;

    await user.save();


    return res.status(200)
        .json(new ApiResponse(200, "Warden logged in successfully", { email, password, accessToken, refreshToken }));
})

//Logout
export const logout = asyncHandler(async (req, res, next) => {
    
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
    
})

//Change Password
export const changePassword = asyncHandler(async (req, res, next) => {

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

    //     //To be Tested
    //     const text = `
    //     <h3>Hello ${user.username},</h3>
    //     <p>Your password has been successfully changed.</p>
    //     <p>If this wasn't you, please contact support immediately.</p>
    //     <br>
    //     <p>Regards,<br>Hostel Management Team</p>
    // `
    //     await sendEmail(user.email, "Password Changed", text)


    return res.status(200)
        .json(new ApiResponse(200, "Password Changed Successfully"))


})

//Forgot Password
export const forgotPassword = asyncHandler(async (req, res, next) => {
    const { email } = req.body
    if (!email) {
        return next(new ApiError(400, "Email is required"))
    }
    const user = await User.findOne({ where: { email } })
    if (!user) {
        return next(new ApiError(404, "User Not Found"))
    }
    const token = jwt.sign({ id: user.id }, process.env.ACCESS_TOKEN_SECRET, { expiresIn: '10m' });

    if (user.otp && new Date() < user.otpExpires) {
        // OTP exists and hasn't expired
        return res.status(200).json(new ApiResponse(200, "OTP already sent to your email",{token}));
    }

    //Generate OTP
    const otp = crypto.randomInt(100000, 999999).toString();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000 + (5.5 * 60 * 60 * 1000));

    // Save OTP to DB
    await user.update({ otp, otpExpires });

    // try {
    //     // Send OTP via email
    //     await sendEmail(email, "Password Reset OTP", `Your OTP is: ${otp}`);
    // }
    // catch (error) {
    //     return next(new ApiError(500, "Error sending OTP email"));  // Error handling for email sending
    // }
    return res.status(200)
        .json(new ApiResponse(200, "OTP sent to your email",{token}))

})

//reset password
export const resetPassword = asyncHandler(async (req, res, next) => {
    const { newPassword } = req.body
    if (!newPassword) {
        return next(new ApiError(400, "Password field empty"))
    }

    const token = req.headers['authorization']?.split(' ')[1];

    if (!token) {
        return next(new ApiError(401, "Token required"));
    }

    let decoded;
    try {
        decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
        console.log("Token verified", decoded);
    } 
    catch (err) {
        console.log("JWT verification error:", err);
        return next(new ApiError(401, "Invalid or Expired Token"));
    }
    const user = await User.findOne({ where: { id: decoded.id } });
    if (!user) {
        return next(new ApiError(404, "User not found"))
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10)

    user.password = hashedPassword
    await user.save()

    //     //To be Tested
    //     const text = `
    //     <h3>Hello ${user.username},</h3>
    //     <p>Your password has been reset.</p>
    //     <p>If this wasn't you, please contact support immediately.</p>
    //     <br>
    //     <p>Regards,<br>Hostel Management Team</p>
    // `
    //     try {
    //         await sendEmail(user.email, "Password Reset", text)
    //     }
    //     catch (error) {
    //         return next(new ApiError(500, "Email was not send"))
    //     }
    return res.status(200)
        .json(new ApiResponse(200, "Password Reset"))
})

//verify otp
export const verifyOTP = asyncHandler(async (req, res, next) => {
    const { otp } = req.body
    if (!otp) {
        return next(new ApiError(400, "OTP Field Empty"))
    }
    const token = req.headers['authorization']?.split(' ')[1];

    if (!token) {
        return next(new ApiError(401, "Token required"));
    }

    let decoded;
    try {
        decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
        console.log("Token verified", decoded);
    } 
    catch (err) {
        console.log("JWT verification error:", err);
        return next(new ApiError(401, "Invalid or Expired Token"));
    }
    const user = await User.findOne({ where: { id: decoded.id } });
    console.log(user)

    if (!user) {
        return next(new ApiError(404, "User Not Found"))
    }
    if (user.otp != otp || new Date() > user.otpExpires) {
        return next(new ApiError(400, "Invalid OTP"))
    }


    // OTP is valid, reset it
    await user.update({ otp: null, otpExpires: null });

    return res.status(200)
        .json(new ApiResponse(200, "OTP Verified"))
})

//refesh Tokens
export const refreshToken = asyncHandler(async (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1];
    if (!token) {
        return next(new ApiError(401, "Access Denied"));
    }
    console.log('Token received:', token);

    let decoded;
    try {
        decoded = jwt.verify(token, process.env.REFRESH_TOKEN_SECRET);
        console.log("Token verified", decoded);
    }
    catch (err) {
        return next(new ApiError(401, err));
    }
    const user = await User.findOne({ where: { email: decoded.email } })
    if (!user) {
        return next(new ApiError(404, "User not found"))
    }
    const accessToken = user.generateAccessToken()

    return res.status(200)
        .json(new ApiResponse(200, "token refreshed", { accessToken }))

})

export const leaveregister=asyncHandler(async(req,res,next)=>{
    const {date,remarks}=req.body
    if(!date||!remarks)
    {
        return next(new ApiError(400,"Fill all fields"))
    }
    if(!["Entry","Exit"].includes(remarks))
    {
        return next(new ApiError(400,"Invalid Remarks"))
    }
    const student_id=req.user.id


    if(remarks==="Exit")
    {
        await LeaveRegister.create({student_id:student_id,remarks:remarks,date:date})
        await User.update({status:"Absent"},{where:{id:student_id}})
    }
    else if(remarks==="Entry")
    {
        const lastExit=await LeaveRegister.findOne({where:{student_id},order: [['date', 'DESC']]})
        if(lastExit.remarks=="Entry")
        {
            return next(new ApiError(404,"No Exit Record Found"))
        }
        
        await LeaveRegister.create({student_id:student_id,remarks:remarks,date:date,})
        await User.update({status:"Present",totalAbsentDays:0},{where:{id:student_id}})
    }

    return res.status(200)
    .json(new ApiResponse(200,"Entered into register "))
})

export const viewAbsentStudents=asyncHandler(async(req,res,next)=>{
    const user=await User.findByPk(req.user.id)
    const students=await User.findAll({where:{status:"Absent",block:user.managedBlock},attributes:['username','email']})
    return res.status(200)
    .json(students)
})

export const updateRole=asyncHandler(async(req,res,next)=>{
    const {email,role}=req.body

    if(!email||!role)
    {
        return next(new ApiError(400,"Fill All Fields"))
    }
    const roles=["Student","Admin","Warden"]
    if(!roles.includes(role))
    {
        return next(new ApiError(400,"Invalid Role"))
    }
    const user=await User.findOne({where:{email}})
    if(!user)
    {
        return next(new ApiError(404,"User Not Found"))
    }
    user.role=role
    await user.save()
    return res.status(200)
    .json(new ApiResponse(200,"Role Updated"))
})

export const addComplaint=asyncHandler(async(req,res,next)=>{
    const {category,description}=req.body
    const student_id=req.user.id

    if(!category||!description)
    {
        return next(new ApiError(400,"All Fields Are Required"))
    }

    const complaint=await Complaint.create({student_id,category,description})

    return res.status(201)
    .json(new ApiResponse(201,"Complaint Filed"))
})

export const getComplaints=asyncHandler(async(req,res,next)=>{
    const complaints=await Complaint.findAll()
    return res.status(200)
    .json(new ApiResponse(200,"Complaints Fetched",complaints))
})

export const updateComplaintStatus=asyncHandler(async(req,res,next)=>{
    const {id,status}=req.body

    if (!["Pending", "In Progress", "Resolved"].includes(status)) {
        return next(new ApiError(400, "Invalid status value"));
    }

    const complaint = await Complaint.findByPk(id);
    if (!complaint) {
        return next(new ApiError(404, "Complaint not found"));
    }

    complaint.status = status;
    await complaint.save();

    return res.status(200)
    .json(new ApiResponse(200, "Complaint status updated",complaint))
})