# Authentication & Follow API

## Görev

1. Login - Register İşlemleri

-  Ad-Soyad, Email ve Şifre ile kayıt yapılabilen bir register api

> Burada kontrol edilmesi gereken tek şey aynı email'e sahip başka bir kullanıcının olup-olmayışı ve email-validation

- Email ve Şifre ile  giriş yapılabilen bir login api
      
     Login api'si iki aşamadan oluşacaktır

     > Kullanıcı Email ve Şifresini bir servise gönderir. Servis başarılı bir sonuç verirse bir refresh token ile response döner. Response ile gelen refresh token kullanım süresi 6 aydır.

     > Kullanıcı bu refresh token ile jwt-token talep eder. Bu jwt-token'in kullanım süresi sadece 15 dk'dır, kullanım süresi dolduğunda başka bir işlem yapılacaksa refresh token ile yeniden jwt-token talep edilir

2. Takipleşme Kurgusu için gerekli api

- Kayıtlı olan bir kullanıcı, kayıtlı olan bir başka kullanıcıya takip isteği gönderir.

> Takip edilen kullanıcıya RabbitMQ kullanılarak işlem kuyrugu convansiyonuna göre takip bilgisi için mail gönderimi sağlanır.


## Yapılandırma

* Ruby version = ruby 3.0.0
* Rails version = 6.1.1
* Authentication: JWT
* Database = Postgresql

## Durum

Register API | Login API | JWT API | Follow API | RabbitMQ 
:------------ | :-------------| :-------------| :------------- | :-------------
:heavy_check_mark: | :heavy_check_mark: |  :heavy_check_mark: | :heavy_check_mark: | :clock3:

## Login & Register Senaryosu

> Kullanıcı Kayıt olur

![image](https://user-images.githubusercontent.com/62894501/106332698-5aa13f00-6298-11eb-90a4-5db28480962a.png)

> Parolayı boş ve email adresini hatalı girer

![image](https://user-images.githubusercontent.com/62894501/106332429-dbac0680-6297-11eb-9ab3-abbbc73562be.png)

> Benzer mail adresi girer

![image](https://user-images.githubusercontent.com/62894501/106332477-f2eaf400-6297-11eb-82d9-0ee97eda306b.png)

> Mailini veya şifresini yanlış girer

![image](https://user-images.githubusercontent.com/62894501/106333196-32fea680-6299-11eb-9a36-a2462b7c0895.png)

> Başarılı bir giriş yapar ve 6 aylık refresh token alır

![image](https://user-images.githubusercontent.com/62894501/106333014-e4e9a300-6298-11eb-8cdc-a0223c57f4e7.png)

> Refresh token kullanarak, 15 dakikalık access token alır

![image](https://user-images.githubusercontent.com/62894501/106333281-5aee0a00-6299-11eb-8bd5-23ea67586efe.png)

> Access Tokenı alma esnasında, Refresh Tokenı hatalı girer

![image](https://user-images.githubusercontent.com/62894501/106333336-7fe27d00-6299-11eb-9400-a4b3149cfc44.png)

> Loginde ne refresh token ne de email girer

![image](https://user-images.githubusercontent.com/62894501/106333389-9be61e80-6299-11eb-8fe3-fb30a0c24cdf.png)

## User CRUD Senaryosu

> Access Tokenı Http isteklerinin Header kısmına yazar ve bu şekilde tüm isteklerde Authorization işlemi gerçekleşir

![image](https://user-images.githubusercontent.com/62894501/106333540-ef586c80-6299-11eb-9397-f907178fe141.png)

> Access Token girmezse

![image](https://user-images.githubusercontent.com/62894501/106337897-82e26b00-62a3-11eb-9742-f45903f1fc29.png)

> Access Token 15 dk lık süresi dolarsa

![image](https://user-images.githubusercontent.com/62894501/106337879-778f3f80-62a3-11eb-8232-fb9cede699e7.png)

> Access Token ile tüm kullanıcıları listeleyebilir

![image](https://user-images.githubusercontent.com/62894501/106333679-42caba80-629a-11eb-9a2a-401d2f73f6cd.png)

> Access Token ile belirli bir kişiye bakabilir

![image](https://user-images.githubusercontent.com/62894501/106333789-73aaef80-629a-11eb-91ca-8227f9967d6e.png)

> Access Token ile belirli bir kişiyi güncelleyebilir

![image](https://user-images.githubusercontent.com/62894501/106333917-b076e680-629a-11eb-90df-070a88d9589b.png)

> Access Token ile belirli bir kişiyi silebilir

![image](https://user-images.githubusercontent.com/62894501/106334078-fb90f980-629a-11eb-8a6e-92e0f1e65e2c.png)

## Follow Senaryosu

> Access Token ile kimliği belli olan kullanıcı, takip isteği atmak istediği kişinin sayfasına gelerek GET isteği atar.
Bu şekilde takip isteği gönderilmiş olur.

![image](https://user-images.githubusercontent.com/62894501/106338395-c5f10e00-62a4-11eb-8f35-b4d109c3a5a0.png)

