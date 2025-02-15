import {app} from './app.js';
import dotenv from 'dotenv';
import { connectDB, syncDB } from './db/db.js';

dotenv.config({
    path: './env'
});

//connect to database
connectDB()
.then(()=>{
    app.listen(8000,()=>{
        console.log('Server is running on port 8000');
    })
})
.catch((error)=>{
    console.log("DB connection failed.....")
})
try 
{
    syncDB()
    console.log("DB synced")
} 
catch (error) 
{
    console.log("Sync failed")
}
