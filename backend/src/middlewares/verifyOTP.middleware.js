import { asyncHandler } from "../utils/asyncHandler.js";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";

export const verifyOTP=asyncHandler(async(req,res,next)=>{
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