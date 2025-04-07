import { Router} from "express";
import { loginStudent ,loginWarden ,loginAdmin,logout ,changePassword, forgotPassword,verifyOTP,resetPassword,refreshToken,leaveregister,viewAbsentStudents ,updateRole,addComplaint,getComplaints,updateComplaintStatus,updateStatus} from "../controllers/user.controllers.js";
import { publishMessBill,viewMyBills,viewBills,createOrder,verifyPayment,getTransactionHistory,viewMyComplaints,getAdminOverviewUsers,getMessBillSummary,getPendingBills,getComplaintsOverview,getPresentCount,viewDetails,getTodaysLeaveApplications} from "../controllers/user.controllers.js";
import { attendanceFetch,attendanceSave } from "../controllers/user.controllers.js";
import { verifyJWT } from "../middlewares/auth.middleware.js";
import { verifyRole } from "../middlewares/authrole.middleware.js";
import { changePasswordLimiter } from "../middlewares/ratelimiter.middleware.js";
import {cronJobs} from "../../scripts";

const router = Router();

router.route("/loginstudent").post(loginStudent);
router.route("/loginwarden").post(loginWarden);
router.route("/loginadmin").post(loginAdmin);
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
router.route("/viewmycomplaints").get(verifyJWT,verifyRole(["Student","Admin"]),viewMyComplaints)
router.route("/updatecomplaintstatus").post(verifyJWT,verifyRole(["Warden","Admin"]),updateComplaintStatus)
router.route("/publishmessbill").post(verifyJWT,verifyRole(["Warden","Admin"]),publishMessBill)
router.route("/viewmessbill").get(verifyJWT,verifyRole(["Student","Admin"]),viewMyBills)
router.route("/viewbills").post(verifyJWT,verifyRole(["Warden","Admin"]),viewBills)
router.route("/createorder").post(verifyJWT,verifyRole(["Student","Admin"]),createOrder)
router.route("/verifypayment").post(verifyJWT,verifyRole(["Student","Admin"]),verifyPayment)
router.route("/gettransactionhistory").get(verifyJWT,verifyRole(["Student","Admin"]),getTransactionHistory)
router.route("/getadminoverviewusers").get(verifyJWT,verifyRole(["Admin"]),getAdminOverviewUsers)
router.route("/getmessbillsummary").get(verifyJWT,verifyRole(["Admin"]),getMessBillSummary)
router.route("/getpendingbills").get(verifyJWT,verifyRole(["Admin"]),getPendingBills)
router.route("/getcomplaintsoverview").get(verifyJWT,verifyRole(["Admin"]),getComplaintsOverview)
router.route("/getpresentcount").get(verifyJWT,verifyRole(["Admin","Warden"]),getPresentCount)
router.route("/viewdetails").get(verifyJWT,verifyRole(["Warden","Admin","Student"]),viewDetails)
router.route("/gettodaysapplied").post(verifyJWT,verifyRole(["Warden","Admin"]),getTodaysLeaveApplications)
router.route("/updatestatus").post(verifyJWT,verifyRole(["Warden","Admin"]),updateStatus)
router.route("/attendancesave").post(verifyJWT,verifyRole(["Warden","Admin"]),attendanceSave)
router.route("/attendancefetch").post(verifyJWT,verifyRole(["Warden","Admin"]),attendanceFetch)
router.route("/cronjobs").get(cronJobs);







export default router;