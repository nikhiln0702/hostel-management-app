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
        type: DataTypes.STRING, //not created
        allowNull: true
    },
    otpExpires: {
        type: DataTypes.DATE,//not created
        allowNull: true
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
            { email: this.email },
            process.env.ACCESS_TOKEN_SECRET,
            { expiresIn: process.env.ACCESS_TOKEN_EXPIRY || "1h" }
        )
    } catch (error) {
        throw Error(error)
    }
}

User.prototype.generateRefreshToken = function () {
    try {
        return jwt.sign(
            { email: this.email},
            process.env.ACCESS_TOKEN_SECRET,
            { expiresIn: process.env.REFRESH_TOKEN_EXPIRY || "7d" }
        )
    } catch (error) {
        throw Error(error)
    }
}






export { User }