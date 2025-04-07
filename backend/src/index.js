import { app } from './app.js';
import dotenv from 'dotenv';
import { connectDB, syncDB } from './db/db.js';
// import "../scripts/cronJobs.js"; // Cron jobs file
import { MessBill } from './models/messbill.models.js';
import { User } from './models/user.models.js';
import { Transaction } from './models/transaction.models.js';
import { Attendance } from './models/attendance.models.js';
dotenv.config({
    path: './env', // Ensure .env file is correctly configured
});

const startServer = async () => {
    try {
        // First, connect to the database
        await connectDB();
        
        // Sync DB after connection
        await syncDB();

        // Then, start the server after syncing DB
        app.listen(7000, () => {
            console.log('Server is running on port 7000 and DB is connected');
        });
    } catch (error) {
        console.log("Server startup failed:", error);
    }
};

// Call the function to start the server
startServer();
