import { DataTypes } from "sequelize";
import { sequelize } from '../db/db.js';

const LeaveRegister = sequelize.define("EntryExitLog", {
    student_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    remarks: {
        type: DataTypes.ENUM("Entry", "Exit"),
        allowNull: false
    },
    date: {
        type: DataTypes.DATEONLY,  // Storing only the date (no time)
        allowNull: false
    }
   
}, {
    timestamps: true  // Includes 'createdAt' and 'updatedAt'
});

export {LeaveRegister}
