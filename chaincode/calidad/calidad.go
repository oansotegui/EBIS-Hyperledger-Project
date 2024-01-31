package main

import (
    "encoding/json"
    "fmt"

    "github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SmartContract proporciona funciones para manejar el control de calidad
type SmartContract struct {
    contractapi.Contract
}

// Inspeccion representa un examen de calidad para un lote de fármacos
type Inspeccion struct {
    LoteID          string `json:"loteID"`
    FechaInspeccion string `json:"fechaInspeccion"` // Utilizar formato de fecha estandarizado, por ejemplo: "2006-01-02T15:04:05Z07:00"
    Resultado       string `json:"resultado"`       // Por ejemplo: "Aprobado", "Rechazado", "Requiere revisión"
    Comentarios     string `json:"comentarios"`
    Inspector       string `json:"inspector"` // ID del inspector o entidad que realizó la inspección
}

// InitLedger añade una entrada de inspección de prueba al ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
    inspecciones := []Inspeccion{
        {LoteID: "LOTE1234", FechaInspeccion: "2023-04-01T12:00:00Z", Resultado: "Aprobado", Comentarios: "Cumple con especificaciones.", Inspector: "INSPECTOR01"},
    }

    for _, inspeccion := range inspecciones {
        inspeccionJSON, err := json.Marshal(inspeccion)
        if err != nil {
            return err
        }
        err = ctx.GetStub().PutState(inspeccion.LoteID, inspeccionJSON)
        if err != nil {
            return fmt.Errorf("failed to put to world state. %v", err)
        }
    }
    return nil
}

// RegistrarInspeccion agrega una nueva inspección de calidad al ledger
func (s *SmartContract) RegistrarInspeccion(ctx contractapi.TransactionContextInterface, loteID string, fechaInspeccion string, resultado string, comentarios string, inspector string) error {
    inspeccion := Inspeccion{
        LoteID:          loteID,
        FechaInspeccion: fechaInspeccion,
        Resultado:       resultado,
        Comentarios:     comentarios,
        Inspector:       inspector,
    }

    inspeccionJSON, err := json.Marshal(inspeccion)
    if err != nil {
        return err
    }

    return ctx.GetStub().PutState(loteID, inspeccionJSON)
}

// ConsultarInspeccion devuelve la inspección de calidad almacenada en el ledger para un lote específico
func (s *SmartContract) ConsultarInspeccion(ctx contractapi.TransactionContextInterface, loteID string) (*Inspeccion, error) {
    inspeccionJSON, err := ctx.GetStub().GetState(loteID)
    if err != nil {
        return nil, fmt.Errorf("failed to read from world state: %v", err)
    }
    if inspeccionJSON == nil {
        return nil, fmt.Errorf("the inspeccion %s does not exist", loteID)
    }

    var inspeccion Inspeccion
    err = json.Unmarshal(inspeccionJSON, &inspeccion)
    if err != nil {
        return nil, err
    }

    return &inspeccion, nil
}

func main() {
    chaincode, err := contractapi.NewChaincode(&SmartContract{})
    if err != nil {
        fmt.Printf("Error create control-calidad chaincode: %s", err.Error())
        return
    }

    if err := chaincode.Start(); err != nil {
        fmt.Printf("Error starting control-calidad chaincode: %s", err.Error())
    }
}