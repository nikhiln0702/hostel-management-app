import { DataTypes } from "sequelize";
import { sequelize } from "../db/db.js";
import { User } from "./user.models.js";

const Transaction = sequelize.define("Transaction", {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        allowNull: false,
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
    billId: {
        type: DataTypes.STRING,
        allowNull: false
    },
    orderId: {
        type: DataTypes.STRING,
        allowNull: false
    },
    paymentId: {
        type: DataTypes.STRING,
        allowNull: false
    },
    amount: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    status: {
        type: DataTypes.STRING,
        defaultValue: "Pending"
    },
    month:{
        type:DataTypes.STRING
    },
    year:{
        type:DataTypes.INTEGER
    }
});
Transaction.belongsTo(User, { foreignKey: "studentId" });
export { Transaction };