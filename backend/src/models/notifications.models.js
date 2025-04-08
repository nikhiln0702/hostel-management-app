import { DataTypes } from "sequelize";
import { sequelize } from "../db/db.js";
import { User } from "./user.models.js";

const Notifications=sequelize.define("Notifications",{
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
    message: {
        type: DataTypes.TEXT,
        allowNull: false
      },
    is_read: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
      }
})

Notifications.belongsTo(User, { foreignKey: "student_id" });

export {Notifications}