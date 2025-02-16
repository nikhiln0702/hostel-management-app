import express from 'express';
import cors from 'cors';
import userRouter from './routes/user.routes.js';

const app = express();

// app.use(cors({
//     origin: 'http://localhost:8000',
//     credentials: true
// }));
app.use(cors());
app.use(express.json({limit:'16kb'}));
// app.use(express.urlencoded({extended:true,limit:'16kb'}));



//Declare a route
app.use('/api/v1',userRouter);

export { app };