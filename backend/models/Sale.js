const mongoose = require("mongoose");

const saleSchema = new mongoose.Schema(
    {
        invoiceNumber: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        },

        saleDate: {
        type: Date,
        required: true,
        },

        customerName: {
        type: String,
        required: true,
        trim: true,
        },

        itemQuantity: {
        type: Number,
        required: true,
        min: 1,
        },

        totalSale: {
        type: Number,
        required: true,
        min: 0,
        },

        createdBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true,
        },
    },
    {
        timestamps: true,
    }
);

module.exports = mongoose.model("Sale", saleSchema);