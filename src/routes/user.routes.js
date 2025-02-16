import { Router} from "express";
import { loginStudent ,loginWarden ,logout ,changePassword} from "../controllers/user.controllers.js";
import { verifyJWT } from "../middlewares/auth.middleware.js";
import { changePasswordLimiter } from "../middlewares/ratelimit.middleware.js";

const router = Router();

router.route("/loginstudent").post(loginStudent);
router.route("/loginwarden").post(loginWarden);

//Secured Routes
router.route("/logout").post(verifyJWT,logout);
router.route("/changepassword").post(verifyJWT,changePasswordLimiter,changePassword)


export default router;