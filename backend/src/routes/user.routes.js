import { Router} from "express";
import { loginStudent , loginWarden,logout} from "../controllers/user.controllers.js";
import { verifyJWT } from "../middlewares/auth.middleware.js";

const router = Router();

router.route("/loginstudent").post(loginStudent);
router.route("/loginwarden").post(loginWarden);

//Secured Routes
router.route("/logout").post(verifyJWT,logout);

export default router;