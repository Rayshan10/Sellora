const express = require("express");
const cors = require("cors");
require("dotenv").config();

const connectDB = require("./config/database");
const authRoutes = require("./routes/authRoutes");
const salesRoutes = require("./routes/salesRoutes");

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Database
connectDB();

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/sales", salesRoutes);

// Test route
app.get("/", (req, res) => {
    res.json({
        message: "Sellora API is running",
        status: "success",
    });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
    console.log(`Sellora API running on http://localhost:${PORT}`);
});