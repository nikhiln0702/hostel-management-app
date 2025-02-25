import cron from "node-cron";
import { Op } from "sequelize";
import { User } from "../src/models/user.models.js";

//  Runs every minute for testing
cron.schedule("0 0 * * *", async () => {
    console.log("Running daily absence check...");
  
    try {
      let flag=0
      // Find all users who are marked as absent
      const absentUsers = await User.findAll({
        where: { status: "Absent" },
      });

      
      for (const user of absentUsers) {
        if (user.totalAbsentDays >= 5)
        {
          flag=1
        }
        // Increment totalAbsentDays
        user.totalAbsentDays += 1;
        if(flag==1)
          {
            user.totalPresentDays -= 1;
          }
  
        // If the user has been absent for 5 consecutive days, reduce from days_present
        if ((user.totalAbsentDays >= 5) && (flag==0)) {
          user.totalPresentDays = Math.max(0, user.totalPresentDays - 5);
          // user.totalAbsentDays = 0; // Reset count after deduction
          flag=1
        }
        await user.save();
      }
  
      console.log("Absence check completed.");
    } catch (error) {
      console.error("Error updating absent days:", error);
    }
  });