import jwt from "jsonwebtoken";
import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { User } from "../models/user.models.js";


export const verifyJWT=asyncHandler(async(req,res,next)=>{
    try{
        console.log("1")
        const token=req.header("Authorization")?.replace("Bearer ","");
        console.log("2")
        if(!token){
            return next(new ApiError(401,"Access Denied"));
        }
        console.log("verifyying....")
        let decoded;
        try {
            decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
            console.log("Token verified", decoded);
        } catch (err) {
            console.log("JWT verification error:", err);
            throw new ApiError(401, "Invalid or Expired Token");
        }
        console.log("Decoded Email:", decoded.email);

        const user=await User.findOne({where:{email:decoded.email}})
        if (user.refreshToken === null) {
            throw new ApiError(401, "Refresh token no longer valid. Please log in again.");
        }

        

        if(!user){
            throw new ApiError(401,"Invalid Access Token")
        }
        req.user=user;

        next();
    }
    catch(error){
        throw new ApiError(401,"Invalid Token");
    }
})