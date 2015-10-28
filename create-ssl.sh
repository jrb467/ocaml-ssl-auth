#!/bin/bash
echo "Generating key and signing request..."
echo -n "Output directory: "
read dir
openssl genrsa -out $dir/privateKey.pem 2048
openssl req -new -key $dir/privateKey.pem -out $dir/csr.pem
echo -n "Self-sign (s), sign with a different CA key (k), or save the signing request (q)? [S/k/q]:"
read option
case $option in
    k|K)
        echo -n "Enter CA certificate location: "
        read cfile
        echo -n "Enter CA private key location: "
        read kfile
        openssl x509 -req -days 9999 -in $dir/csr.pem -CA $cfile -CAkey $kfile -out $dir/certificate.pem
        ;;
    q|Q)
        echo "Process finished. Signing request located at './config/sslcerts/csr.pem'"
        return
        ;;
    *)
        openssl x509 -req -days 365 -in $dir/csr.pem -signkey $dir/privateKey.pem -out $dir/certificate.pem
        ;;
esac

rm $dir/csr.pem
chmod 600 $dir/privateKey.pem $dir/certificate.pem
