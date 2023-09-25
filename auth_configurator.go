package main

// Ensure to statically link binary when compiling, use this build command
// GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build auth_configurator.go
//
//You can build the binary or download it from cloud storage bucket
//it would of made to archive to much submit in the portal.

import (
        "fmt"
        "net/http"
        "os"
        "net"
        "context"
        "time"
        "io"
)

func main() {

        //Basic usage message to interest the hacker
        if len(os.Args) != 2 {
                fmt.Println("############ Device system ssh configurator #################\n \n\n Please do not use program without permission\n Please do not run beware when running program\n\nThis program is encase of network outtages\n#############################################################")
                os.Exit(1)
        }

        //Configure custom resolver by setting the loopback interface
        r := &net.Resolver{
            PreferGo: true,
            Dial: func(ctx context.Context, network, address string) (net.Conn, error) {
                d := net.Dialer{
                    Timeout: time.Millisecond * time.Duration(10000),
                }
                return d.DialContext(ctx, network, "1.0.1.0:553")
            },
        }

        url := "support.device.system.o3h"
        ip_addr, err := r.LookupHost(context.Background(), url)
        if err != nil {
            fmt.Println("Error: can not resolve IP address")
            os.Exit(1)
        }
        response, err := http.Get(fmt.Sprintf("http://%s/ssh_pubkey_file", ip_addr[0]))
        if err != nil {
                fmt.Println("Unkown error:", err.Error())
                os.Exit(2)
        }
        if response.Status != "200 OK" {
                fmt.Println("Error: retrieving ssh public key file", response.Status)
                os.Exit(2)
        }

        filePath := fmt.Sprint(os.Args[1], ".ssh/authorized_keys")
	    file, err := os.Create(filePath)
	    os.Chmod(filePath, 0600)
	    defer file.Close()

        //Write response body to local file
        respReader := response.Body
        fmt.Println("Writing auth data to file")
        if b, err := io.ReadAll(respReader); err == nil {
            file.Write(b)
        }
        os.Exit(0)
}
