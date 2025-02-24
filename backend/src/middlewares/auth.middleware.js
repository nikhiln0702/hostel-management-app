import jwt from "jsonwebtoken";
import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { User } from "../models/user.models.js";


export const verifyJWT=asyncHandler(async(req,res,next)=>{
    try{
        const token = req.headers['authorization']?.split(' ')[1];
        if(!token){
            return next(new ApiError(401,"Access Denied"));
        }
        let decoded;
        try {
            decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
            // console.log("Token verified", decoded);
        } catch (err) {
            console.log("JWT verification error:", err);
            return next(new ApiError(401, "Invalid or Expired Token"));
        }

        let user;
        try 
        {
            user=await User.findOne({where:{email:decoded.email}})
        } 
        catch (error) 
        {
            throw new ApiError(401,"Refresh token no longer valid. Please log in again.")
        }
        if (user.refreshToken === null) {
            return next( new ApiError(401, "Refresh token no longer valid. Please log in again."));
        }

        

        if(!user){
            return next (new ApiError(401,"Invalid Access Token"))
        }
        req.user=user;

        next();
    }
    catch(error){
        throw new ApiError(401,"Invalid Token");
    }
})