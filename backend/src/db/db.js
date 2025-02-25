//connect db function
import { Sequelize } from "sequelize";




const sequelize = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASS, {
    host: process.env.DB_HOST,
    port:3306,
    dialect: "mysql",
    logging :false // Logs SQL queries to the console

});

const connectDB= async()=>{
    try 
    {

        await sequelize.authenticate();
    } 
    catch (error) 
    {
        console.log("Database connection failed",error)
        process.exit(1)
    }
}

const syncDB=async()=>{
    try 
    {
        await sequelize.sync({alter:false})
    } 
    catch (error) 
    {
        console.log("Database sync failed",error)
        process.exit(1)
    }
}


export {sequelize,connectDB,syncDB};
