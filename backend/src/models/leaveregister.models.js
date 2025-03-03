import { DataTypes } from "sequelize";
import { sequelize } from '../db/db.js';
import { User } from "./user.models.js";

const LeaveRegister = sequelize.define("LeaveRegister", {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        allowNull: false,
        primaryKey: true
    },
    student_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: User,
            key: "id",
          },
    },
    remarks: {
        type: DataTypes.ENUM("Entry", "Exit"),
        allowNull: false
    },
    date: {
        type: DataTypes.DATEONLY,  // Storing only the date (no time)
        allowNull: false
    },
   
});

LeaveRegister.belongsTo(User, { foreignKey: "student_id" });

export {LeaveRegister}
