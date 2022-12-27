const express = require("express")
const cors = require("cors")
const http = require("http")
const fs = require("fs")
const multer = require("multer")
const path = require("path")

const app = express()
const port = 5000

app.use(cors())
app.use((req, res, next) => {
	res.header("Access-Control-Allow-Origin", "*")
	res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization")
	next()
})

const diskStorage = multer.diskStorage({
	destination: (req, file, cb) => {
		cb(null, "./files")
	},
	filename: (req, file, cb) => {
		console.log(file.mimetype)
		const extName = file.mimetype.split("/")[1]
		let fileName = ""
		if (file && file.originalname.includes(extName) && extName != "octet-stream") {
			fileName = file.originalname
		} else {
			fileName = `${Date.now()}_${file?.originalname.toLowerCase()}.${extName}`.split(" ").join("-")
		}
		cb(null, fileName)
	},
})

const upload = multer({
	storage: diskStorage,
})

app.get("/", (req, res) => {
	res.send("Hello there")
})

app.post("/image_upload", upload.single("image"), (req, res) => {
	if (req.file) {
		console.log("image found")
		res.send("File recieved")
	} else {
		console.log("image not found")
		res.status(400).send("Please upload a valid image")
	}
})

app.listen(port, () => {
	console.log(`Example app listening on port ${port}`)
})
