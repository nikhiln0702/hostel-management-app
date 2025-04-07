import cron from "node-cron";
import { Op } from "sequelize";
import { User } from "../src/models/user.models.js";
console.log("Cron jobs loaded")

//  Runs every minute for testing
cron.schedule("30 18 * * *", async () => {
    // console.log("Running daily absence check...");
  
    try {
      let flag=0
      // Find all users who are marked as absent
      const absentUsers = await User.findAll({
        where: { status: "Absent" },
      });

      
      for (const user of absentUsers) {
        user.totalAbsentDays += 1;

  if (user.totalAbsentDays === 5) {
    user.totalPresentDays = Math.max(0, user.totalPresentDays - 5);
  } else if (user.totalAbsentDays > 5) {
    user.totalPresentDays = Math.max(0, user.totalPresentDays - 1);
  }

  await user.save();
      }
  
      console.log("Absence check completed.");
    } catch (error) {
      console.error("Error updating absent days:", error);
    }
  });