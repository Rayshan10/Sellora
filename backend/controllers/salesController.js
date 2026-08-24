const Sale = require("../models/Sale");

const getSales = async (req, res) => {
    try {
        const sales = await Sale.find()
        .populate("createdBy", "username name")
        .sort({ createdAt: -1 });

        res.json({
        message: "Data penjualan berhasil diambil",
        data: sales,
        });
    } catch (error) {
        console.error("Get sales error:", error);

        res.status(500).json({
        message: "Gagal mengambil data penjualan",
        });
    }
};

const getSaleById = async (req, res) => {
    try {
        const sale = await Sale.findById(req.params.id)
        .populate("createdBy", "username name");

        if (!sale) {
        return res.status(404).json({
            message: "Data penjualan tidak ditemukan",
        });
        }

        res.json({
        message: "Data penjualan berhasil diambil",
        data: sale,
        });
    } catch (error) {
        console.error("Get sale error:", error);

        res.status(500).json({
        message: "Gagal mengambil data penjualan",
        });
    }
};

const createSale = async (req, res) => {
    try {
        const {
        invoiceNumber,
        saleDate,
        customerName,
        itemQuantity,
        totalSale,
        } = req.body;

        if (
        !invoiceNumber ||
        !saleDate ||
        !customerName ||
        itemQuantity === undefined ||
        totalSale === undefined
        ) {
        return res.status(400).json({
            message: "Semua data penjualan wajib diisi",
        });
    }

    const existingSale = await Sale.findOne({ invoiceNumber });

    if (existingSale) {
        return res.status(409).json({
            message: "Nomor invoice sudah digunakan",
        });
    }

    const sale = await Sale.create({
        invoiceNumber,
        saleDate,
        customerName,
        itemQuantity,
        totalSale,
        createdBy: req.user.id,
    });

    const populatedSale = await sale.populate(
        "createdBy",
        "username name"
    );

    res.status(201).json({
        message: "Data penjualan berhasil ditambahkan",
        data: populatedSale,
        });
    } catch (error) {
        console.error("Create sale error:", error);

        res.status(500).json({
        message: "Gagal menambahkan data penjualan",
        });
    }
};

const updateSale = async (req, res) => {
    try {
        const sale = await Sale.findById(req.params.id);

        if (!sale) {
        return res.status(404).json({
            message: "Data penjualan tidak ditemukan",
        });
        }

        const {
        invoiceNumber,
        saleDate,
        customerName,
        itemQuantity,
        totalSale,
    } = req.body;

    sale.invoiceNumber = invoiceNumber ?? sale.invoiceNumber;
    sale.saleDate = saleDate ?? sale.saleDate;
    sale.customerName = customerName ?? sale.customerName;
    sale.itemQuantity = itemQuantity ?? sale.itemQuantity;
    sale.totalSale = totalSale ?? sale.totalSale;

    await sale.save();

    const updatedSale = await sale.populate(
        "createdBy",
        "username name"
    );

    res.json({
        message: "Data penjualan berhasil diperbarui",
        data: updatedSale,
    });

    } catch (error) {
        console.error("Update sale error:", error);

        res.status(500).json({
        message: "Gagal memperbarui data penjualan",
        });
    }
};

const deleteSale = async (req, res) => {
    try {
        const sale = await Sale.findById(req.params.id);

        if (!sale) {
        return res.status(404).json({
            message: "Data penjualan tidak ditemukan",
        });
    }

    await Sale.findByIdAndDelete(req.params.id);

    res.json({
        message: "Data penjualan berhasil dihapus",
        });
    } catch (error) {
        console.error("Delete sale error:", error);

        res.status(500).json({
        message: "Gagal menghapus data penjualan",
        });
    }
};

module.exports = {
    getSales,
    getSaleById,
    createSale,
    updateSale,
    deleteSale,
};