import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { User } from "../models/user.models.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import bcrypt from "bcryptjs";

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

const logout=asyncHandler(async(req,res)=>{
    try 
    {
        const user=req.user
        if(!user){
            throw(new ApiError(404,"User not found"))
        }
        user.refreshToken=null
        console.log("3")
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


export { loginStudent , loginWarden ,logout };