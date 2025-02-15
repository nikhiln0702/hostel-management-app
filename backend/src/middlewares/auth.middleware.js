import jwt from "jsonwebtoken";
import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { User } from "../models/user.models.js";


export const verifyJWT=asyncHandler(async(req,res,next)=>{
    try{
        // Get token from the header file
        const token=req.header("Authorization")?.replace("Bearer ","");
        if(!token){
            return next(new ApiError(401,"Access Denied"));
        }
        //Verify the token
        let decoded;
        try {
            decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
            console.log("Token verified", decoded);
        } catch (err) {
            console.log("JWT verification error:", err);
            throw new ApiError(401, "Invalid or Expired Token");
        }

        // Find User with the refresh token
        const user=await User.findOne({where:{email:decoded.email}})
        if (user.refreshToken === null) {
            throw new ApiError(401, "Refresh token no longer valid. Please log in again.");
        }

        

        if(!user){
            throw new ApiError(401,"Invalid Access Token")
        }
        
        // Store the Refresh values
        req.user=user;

        next();
    }
    catch(error){
        throw new ApiError(401,"Invalid Token");
    }
})