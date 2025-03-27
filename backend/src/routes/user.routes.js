import { Router} from "express";
import { loginStudent ,loginWarden ,logout ,changePassword, forgotPassword,verifyOTP,resetPassword,refreshToken,leaveregister,viewAbsentStudents ,updateRole,addComplaint,getComplaints,updateComplaintStatus} from "../controllers/user.controllers.js";
import { publishMessBill,viewMyBills,viewBills,createOrder,verifyPayment } from "../controllers/user.controllers.js";
import { verifyJWT } from "../middlewares/auth.middleware.js";
import { verifyRole } from "../middlewares/authrole.middleware.js";
import { changePasswordLimiter } from "../middlewares/ratelimiter.middleware.js";


const router = Router();

router.route("/loginstudent").post(loginStudent);
router.route("/loginwarden").post(loginWarden);
router.route("/forgotpassword").post(forgotPassword)
router.route("/verifyotp").post(verifyOTP);
router.route("/resetpassword").post(resetPassword);

//Secured Routes
router.route("/logout").post(verifyJWT,logout);
router.route("/changepassword").post(verifyJWT,changePasswordLimiter,changePassword);
router.route("/refreshtoken").post(refreshToken)
router.route("/leaveregister").post(verifyJWT,verifyRole(["Student","Admin"]),leaveregister)
router.route("/viewstudents").get(verifyJWT,verifyRole(["Warden","Admin"]),viewAbsentStudents)
router.route("/updaterole").post(verifyJWT,verifyRole(["Admin"]),updateRole)
router.route("/addcomplaint").post(verifyJWT,verifyRole(["Student","Admin"]),addComplaint)
router.route("/viewcomplaints").get(verifyJWT,verifyRole(["Warden","Admin"]),getComplaints)
router.route("/updatecomplaintstatus").post(verifyJWT,verifyRole(["Warden","Admin"]),updateComplaintStatus)
router.route("/publishmessbill").post(verifyJWT,verifyRole(["Warden"]),publishMessBill)
router.route("/viewmessbill").get(verifyJWT,verifyRole(["Student","Admin"]),viewMyBills)
router.route("/viewbills").post(verifyJWT,verifyRole(["Warden","Admin"]),viewBills)
router.route("/createorder").post(verifyJWT,verifyRole(["Student","Admin"]),createOrder)
router.route("/verifypayment").post(verifyJWT,verifyRole(["Student","Admin"]),verifyPayment)




export default router;