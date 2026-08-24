const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");

const register = async (req, res) => {
    try {
        const { username, password, name } = req.body;

        if (!username || !password || !name) {
            return res.status(400).json({
                message: "Username, password, dan nama wajib diisi",
            });
        }

        const existingUser = await User.findOne({ username });

        if (existingUser) {
            return res.status(409).json({
                message: "Username sudah digunakan",
            });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const user = await User.create({
            username,
            password: hashedPassword,
            name,
        });

        res.status(201).json({
            message: "Registrasi berhasil",
            user: {
                id: user._id,
                username: user.username,
                name: user.name,
            },
        });
    } catch (error) {
        console.error("Register error:", error);

        res.status(500).json({
            message: "Terjadi kesalahan pada server",
        });
    }
};

const login = async (req, res) => {
    try {
        const { username, password } = req.body;

        if (!username || !password) {
            return res.status(400).json({
                message: "Username dan password wajib diisi",
            });
        }

        const user = await User.findOne({ username });

        if (!user) {
            return res.status(401).json({
                message: "Username atau password salah",
            });
        }

        const isPasswordValid = await bcrypt.compare(
            password,
            user.password
        );

        if (!isPasswordValid) {
            return res.status(401).json({
                message: "Username atau password salah",
            });
        }

        const token = jwt.sign(
            {
                id: user._id,
                username: user.username,
            },
            process.env.JWT_SECRET,
            {
                expiresIn: "1d",
            }
        );

        res.json({
            message: "Login berhasil",
            token,
            user: {
                id: user._id,
                username: user.username,
                name: user.name,
            },
        });
    } catch (error) {
        console.error("Login error:", error);

        res.status(500).json({
            message: "Terjadi kesalahan pada server",
        });
    }
};

const me = async (req, res) => {
    try {
        const user = await User.findById(req.user.id).select("-password");

        if (!user) {
            return res.status(404).json({
                message: "Data user tidak ditemukan",
            });
        }

        res.json({
            message: "Data user berhasil diambil",
            user: {
                id: user._id,
                username: user.username,
                name: user.name,
            },
        });
    } catch (error) {
        console.error("Get user error:", error);

        res.status(500).json({
            message: "Terjadi kesalahan pada server",
        });
    }
};

module.exports = {
    register,
    login,
    me,
};