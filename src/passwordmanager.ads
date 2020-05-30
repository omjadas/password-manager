package PasswordManager with Spark_Mode is
   function Is_PIN(S : in String) return Boolean with
      Post => (if Is_PIN'Result then
         S'Length = 4 and
         (for all I in S'Range => S(I) >= '0' and S(I) <= '9'));

   function Is_URL(S : in String) return Boolean with
      Post => (if Is_URL'Result then
         S'Length <= 1024);

   function Is_Password(S : in String) return Boolean with
      Post => (if Is_Password'Result then
         S'Length <= 100);
end PasswordManager;