//connect db function
import { Sequelize } from "sequelize";




const sequelize = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASS, {
    host: process.env.DB_HOST,
    port:25454,
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
    console.log("Registered models:", sequelize.models);

    await sequelize.sync({ alter:true }).then(() => {
        console.log("Table sync complete");
    }).catch(err => {
        console.error("Error syncing table:", err);
    });
}


export {sequelize,connectDB,syncDB};
