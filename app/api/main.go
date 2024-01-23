package main

import (
    "github.com/gin-gonic/gin"
	// Importa Hyperledger Fabric SDK
)

func main() {
    r := gin.Default()

    // Rutas para trazabilidad
    // Endpoint para crear un fármaco
    r.POST("/farmaco/create", CreateFarmaco)

    // Endpoint para leer un fármaco
    r.GET("/farmaco/read/:id", ReadFarmaco)

    // Endpoint para actualizar un fármaco
    r.POST("/farmaco/update/:id", UpdateFarmaco)

    // Endpoint para eliminar un fármaco
    r.DELETE("/farmaco/delete/:id", DeleteFarmaco)

    // Endpoint para obtener todos los fármacos
    r.GET("/farmaco/getall", GetAllFarmacos)

    // Endpoint para obtener el historial de un fármaco
    r.GET("/farmaco/history/:id", GetFarmacoHistory)

	

    // Rutas para ventas
    r.POST("/ventas/create", CreateVentaHandler)
    r.GET("/ventas/:id", GetVentaHandler)


	

    // Rutas para calidad
    r.POST("/calidad/inspeccion", CreateInspeccionHandler)
    r.GET("/calidad/inspeccion/:id", GetInspeccionHandler)

    r.Run() // Escucha en el puerto 8080 por defecto
}
