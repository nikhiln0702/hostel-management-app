import { DataTypes } from "sequelize";
import { sequelize } from '../db/db.js';
import { User } from "./user.models.js";

const Attendance = sequelize.define('Attendance', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    studentId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: User,
        key: "id",
      },
    },
    date: {
      type: DataTypes.DATEONLY,  // Stores only "YYYY-MM-DD"
      allowNull: false,
    },
    status: {
      type: DataTypes.STRING, // "Present" or "Absent"
      allowNull: false,
    },
  }, {
    timestamps: false, // Don't store createdAt/updatedAt
  });
  Attendance.belongsTo(User,{foreignKey:"studentId"})

  export {Attendance}
  