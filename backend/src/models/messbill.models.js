import { DataTypes } from "sequelize";
import { sequelize } from "../db/db.js";
import { User } from "./user.models.js";

const MessBill = sequelize.define("MessBill", {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        allowNull: false,
        primaryKey: true,
    },
    student_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: User,
            key: "id",
        },
    },
    username: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    mpd_rate: {
        type: DataTypes.FLOAT,
        allowNull: false,
    },
    ksw_charges: {
        type: DataTypes.FLOAT,
        allowNull: false,
    },
    electricity_charges: {
        type: DataTypes.FLOAT,
        allowNull: false,
    },
    rent: {
        type: DataTypes.FLOAT,
        allowNull: true,
    },
    est_charges: {
        type: DataTypes.FLOAT,
        defaultValue: 500,
    },
    days_present: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    total_amount: {
        type: DataTypes.FLOAT,
        allowNull: false,
    },
    status: {
        type: DataTypes.ENUM("Pending", "Paid"),
        defaultValue: "Pending",
    },
    month:{
        type:DataTypes.STRING
    },
    year:{
        type:DataTypes.INTEGER
    },
    month_number:{
        type:DataTypes.INTEGER,
        allowNull:false
    }
});

// Relationship
MessBill.belongsTo(User, { foreignKey: "student_id" });

export { MessBill };
