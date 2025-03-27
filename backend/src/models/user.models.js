import jwt from 'jsonwebtoken';
import { DataTypes } from "sequelize";
import { sequelize } from '../db/db.js';
import bcrypt from "bcryptjs";

const User = sequelize.define("User", {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        allowNull: false,
        primaryKey: true
    },
    username: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true
    },
    email: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
        validate: { isEmail: true }
    },
    password: {
        type: DataTypes.STRING,
        allowNull: false
    },
    refreshToken: {
        type: DataTypes.STRING,
        allowNull: true, 
    },
    otp: {
        type: DataTypes.STRING, 
        allowNull: true
    },
    otpExpires: {
        type: DataTypes.DATE,
        allowNull: true
    },
    status: {
        type: DataTypes.ENUM("Present", "Absent"),
        defaultValue: "Present"
    },
    totalPresentDays: {
         type: DataTypes.INTEGER, 
         defaultValue: 30 
    },
    totalAbsentDays: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    role: {
        type: DataTypes.ENUM("Student", "Warden","Admin","Staff"),
        defaultValue: "Student"
    },
    block: {
        type: DataTypes.STRING,
        allowNull: false
    },
    managedBlock: {
        type: DataTypes.STRING,
        allowNull: true // Null if not a warden
    }

},
    {
        hooks: {
            beforeCreate: async (user) => {
                user.password = await bcrypt.hash(user.password,10);
            }
        }
    }


)
User.prototype.isValidPassword = async function (password) {
    return await bcrypt.compare(password, this.password);
};






User.prototype.generateAccessToken = function () {
    try {
        return jwt.sign(
            { email: this.email,id:this.id },
            process.env.ACCESS_TOKEN_SECRET,
            { expiresIn: process.env.ACCESS_TOKEN_EXPIRY || "30m" }
        )
    } catch (error) {
        throw Error(error)
    }
}

User.prototype.generateRefreshToken = function (rememberMe) {
    try {
        return jwt.sign(
            { email: this.email},
            process.env.REFRESH_TOKEN_SECRET,
            { expiresIn: rememberMe ? "7d" : "1d" }
        )
    } catch (error) {
        throw Error(error)
    }
}






export { User }