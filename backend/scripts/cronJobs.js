import cron from "node-cron";
import { Op } from "sequelize";
import { User } from "../src/models/user.models.js";


cron.schedule("* * * * *", async () => {
    console.log("Running daily absence check...");
  
    try {
      // Find all users who are marked as absent
      const absentUsers = await User.findAll({
        where: { status: "Absent" },
      });
  
      for (const user of absentUsers) {
        // Increment totalAbsentDays
        user.totalAbsentDays += 1;
  
        // If the user has been absent for 5 consecutive days, reduce from days_present
        if (user.totalAbsentDays >= 5) {
          user.totalPresentDays = Math.max(0, user.totalPresentDays - 5);
          user.totalAbsentDays = 0; // Reset count after deduction
        }
  
        await user.save();
      }
  
      console.log("Absence check completed.");
    } catch (error) {
      console.error("Error updating absent days:", error);
    }
  });