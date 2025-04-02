import { DataTypes } from "sequelize";
import { sequelize } from '../db/db.js';
import { User } from "./user.models.js";

const Complaint = sequelize.define("Complaint", {
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
    category: {
        type: DataTypes.STRING,
        allowNull: false
    },
    description: {
        type: DataTypes.TEXT,
        allowNull: false
    },
    status: {
        type: DataTypes.ENUM("Pending", "In Progress", "Resolved"),
        defaultValue: "Pending"
    }
})
Complaint.belongsTo(User, { foreignKey: "student_id" });

export {Complaint}