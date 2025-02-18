import { Router} from "express";
import { loginStudent ,loginWarden ,logout ,changePassword, forgotPassword,verifyOTP,resetPassword,refreshToken} from "../controllers/user.controllers.js";
import { verifyJWT } from "../middlewares/auth.middleware.js";
import { changePasswordLimiter } from "../middlewares/ratelimit.middleware.js";

const router = Router();

router.route("/loginstudent").post(loginStudent);
router.route("/loginwarden").post(loginWarden);
router.route("/forgotpassword").post(forgotPassword)
router.route("/verifyotp").post(verifyOTP);
router.route("resetpassword").post(resetPassword);
router.route("/refreshtoken").post(refreshToken)

//Secured Routes
router.route("/logout").post(verifyJWT,logout);
router.route("/changepassword").post(verifyJWT,changePasswordLimiter,changePassword);


export default router;