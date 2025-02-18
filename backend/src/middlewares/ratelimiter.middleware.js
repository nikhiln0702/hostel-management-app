import rateLimit from "express-rate-limit";


export const changePasswordLimiter = rateLimit({
    windowMs: 60 * 60 * 1000, // 60 minutes
    max: 5, // Limit each IP to 5 requests per windowMs
    message: "Too many password change attempts. Try again later.",
    headers: true,
});
