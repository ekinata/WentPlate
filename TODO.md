# TODO

- YAML yapılandırma ile ayağa kaldırma
- VENDOR PUBLISH ile import edilen paketlerin pkg/ klasörü içine klonlanması ve ilgili bütün import'ların pkg/ klasörünü kullanacak halde düzenlenmesi(Not: ister seçilen bir paket ister tüm paketler için globalde yapılabilir.)
- Make komutlarında verilen ModelName vs argümanının ilk harfi otomatik büyütülecek.
- Docker compose dosyası dev prod vs olarak ayrılacak. Postgres Volume değişikliği engelliyor
- Make komutlarına cache clean eklenecek. Sorun: vm.go oluşturuldu ve silindi. Sonra VM.go eklendiğinde hata veriyor.
- Template db ile geliyor. gorm tanımı ile gelmesi lazım.
- Graceful shutdown
- Cobra-cli
- default sqlite