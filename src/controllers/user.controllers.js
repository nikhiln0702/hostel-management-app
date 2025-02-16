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
const loginStudent=asyncHandler(async (req, res, next) => {
    //Get email and password 
    const { email, password } = req.body;


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
    const refreshToken= user.generateRefreshToken();
    user.refreshToken = refreshToken;

    //Save Token to db
    await user.save();
    return res.status(200)
    .json(new ApiResponse(200, "Student logged in successfully", { email, password,accessToken,refreshToken }));
})

//Login a warden
const loginWarden=asyncHandler(async (req, res, next) => {
    //Get email and password 
    const { email, password } = req.body;
    User(email,password);


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
    const refreshToken= user.generateRefreshToken();

    //Save token to db
    user.refreshToken = refreshToken;
    
    await user.save();


    return res.status(200)
    .json(new ApiResponse(200, "Warden logged in successfully", { email, password,accessToken,refreshToken }));
})

//Logout
const logout=asyncHandler(async(req,res)=>{
    try 
    {
        // Get the User from verifyJWT
        const user=req.user
        if(!user)
        {
            throw(new ApiError(404,"User not found"))
        }
        // Set User's refresh token to null and save to db
        user.refreshToken=null
        await user.save()
    
        return res.status(200)
        .json(new ApiResponse(200,"Logout Successfull"))
    } 
    catch (error) 
    {
        return res.status(500)
        .json(new ApiResponse(500,"Logout Failed"))
    }
})

//Change Password
const changePassword=asyncHandler(async(req,res)=>{
    
    const {oldPassword,newPassword}=req.body
    const userID=req.user.id

    const user=await User.findByPk(userID)

    if(!user)
    {
        throw(new ApiError(404,"User Not Found"))
    }
    const isValidPassword=await user.isValidPassword(oldPassword)

    if(!isValidPassword)
    {
        throw(new ApiError(400,"Incorrect Password"))
    }

    const hashedPassword=await bcrypt.hash(newPassword,10)

    user.password=hashedPassword
    await user.save()

    //To be Tested
    const text= `
    <h3>Hello ${user.username},</h3>
    <p>Your password has been successfully changed.</p>
    <p>If this wasn't you, please contact support immediately.</p>
    <br>
    <p>Regards,<br>Hostel Management Team</p>
`
    await sendEmail(user.email,"Password Changed",text)


    return res.status(200)
    .json(new ApiResponse(200,"Password Changed Successfully"))


})


export { loginStudent ,loginWarden ,logout ,changePassword};