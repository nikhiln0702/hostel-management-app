import {app} from './app.js';
import dotenv from 'dotenv';
import { connectDB, syncDB } from './db/db.js';

dotenv.config({
    path: './env'
});

//connect to database
connectDB()
.then(()=>{
    app.listen(7000,()=>{
        console.log('Server is running on port 7000 and db is connected')
    })
    syncDB()
    console.log("DB synced")
})
.catch((error)=>{
    console.log("DB connection failed.....")
})
