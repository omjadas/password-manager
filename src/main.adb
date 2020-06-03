--Task 4 Report

-- 1:
--  LOCK operation can only be performed if Password Manager is in unlocked state.
--  This security property is specified by the postcondition that states that if Password Manager
--  is unlocked, then master PIN is updated and Password Manager changes to the locked state.

-- 2:
--  UNLOCK operation can only be performed if Password Manager is in locked state.
--  This security property is specified by the postcondition that states that if Password Manager
--  length is the same as before and Password Manager is locked and the PIN provided is correct
--  then Password Manager becomes unlocked.

-- 3:
--  GET operation can only be performed if Password Manager is in unlocked state.
--  This security property is specified by the precondition that states that if Password Manager
--  is in unlocked state and Database has a password for the URL provided, then the password is returned.

-- 4:
--  PUT operation can only be performed if Password Manager is in unlocked state.
--  This security property is specified by the precondition that states that Password Manager cannot be full
--  or it cannot have a password associated with the URL being provided.
--  This security property is also specified by the postcondition that states that Password Manager remains
--  in the same state after this operation is performed.

-- 5:
--  REMOVE operation can only be performed if Password Manager is in unlocked state.
--  This security property is specified by the postcondition that states that after removing the specified entry,
--  Password Manager's state remains the same after the operation is performed.


pragma SPARK_Mode (On);

with PasswordDatabase;
with PasswordManager;
with MyCommandLine;
with MyString;
with MyStringTokeniser;
with PIN;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Containers;
use Ada.Containers;

procedure Main is
   M : PasswordManager.Manager;
   package Lines is new MyString(Max_MyString_Length => 2048);
   S  : Lines.MyString;
begin
   if MyCommandLine.Argument_Count /= 1 then
      return;
   end if;

   if not PasswordManager.Is_PIN(MyCommandLine.Argument(1)) then
      return;
   end if;

   PasswordManager.Init(M,PIN.From_String(MyCommandLine.Argument(1)));

   loop
      if PasswordManager.Locked(M) then
         Put("locked>   ");
      else
         Put("unlocked> ");
      end if;
      Lines.Get_Line(S);
      declare
         Tokens : MyStringTokeniser.TokenArray(1..4) := (others => (Start => 1, Length => 0));
         NumTokens : Natural;
      begin
         MyStringTokeniser.Tokenise(Lines.To_String(S),Tokens,NumTokens);
         if NumTokens = 0 then
            return;
         end if;
         declare
            Command : String := Lines.To_String(Lines.Substring(S,Tokens(1).Start,Tokens(1).Start+Tokens(1).Length-1));
         begin
            if Command = "get" then
               if NumTokens /= 2 then
                  return;
               elsif NumTokens = 2 then
                  declare
                     T : String := Lines.To_String(Lines.Substring(S,Tokens(2).Start,Tokens(2).Start+Tokens(2).Length-1));
                  begin
                     if not PasswordManager.Is_URL(T) then
                        return;
                     end if;
                     declare
                        U : PasswordDatabase.URL := PasswordDatabase.From_String(T);
                     begin
                        if not PasswordManager.Locked(M) and PasswordManager.Has_Password_For(M,U) then
                           Put_Line(PasswordDatabase.To_String(PasswordManager.Get(M,U)));
                        end if;
                     end;
                  end;
               end if;
            elsif Command = "rem" then
               if NumTokens /= 2 then
                  return;
               elsif NumTokens = 2 then
                  declare
                     T : String := Lines.To_String(Lines.Substring(S,Tokens(2).Start,Tokens(2).Start+Tokens(2).Length-1));
                  begin
                     if not PasswordManager.Is_URL(T) then
                        return;
                     end if;
                     declare
                        U : PasswordDatabase.URL := PasswordDatabase.From_String(T);
                     begin
                        if not PasswordManager.Locked(M) then
                           PasswordManager.Remove(M,U);
                        end if;
                     end;
                  end;
               end if;
            elsif Command = "put" then
               if NumTokens /= 3 then
                  return;
               elsif NumTokens = 3 then
                  declare
                     T1 : String := Lines.To_String(Lines.Substring(S,Tokens(2).Start,Tokens(2).Start+Tokens(2).Length-1));
                     T2 : String := Lines.To_String(Lines.Substring(S,Tokens(3).Start,Tokens(3).Start+Tokens(3).Length-1));
                  begin
                     if not (PasswordManager.Is_URL(T1) and PasswordManager.Is_Password(T2)) then
                        return;
                     end if;
                     declare
                        U : PasswordDatabase.URL := PasswordDatabase.From_String(T1);
                        P : PasswordDatabase.Password := PasswordDatabase.From_String(T2);
                     begin
                        if PasswordManager.Length(M) >= PasswordDatabase.Max_Entries and not PasswordManager.Has_Password_For(M,U) then
                           return;
                        end if;
                        if not PasswordManager.Locked(M) then
                           PasswordManager.Put(M,U,P);
                        end if;
                     end;
                  end;
               end if;
            elsif Command = "unlock" then
               if NumTokens /= 2 then
                  return;
               elsif NumTokens = 2 then
                  declare
                     T : String := Lines.To_String(Lines.Substring(S,Tokens(2).Start,Tokens(2).Start+Tokens(2).Length-1));
                  begin
                     if not PasswordManager.Is_PIN(T) then
                        return;
                     end if;
                     declare
                        P : PIN.PIN := PIN.From_String(T);
                     begin
                        if PasswordManager.Locked(M) then 
                           PasswordManager.Unlock(M,P);
                        end if;
                     end;
                  end;
               end if;
            elsif Command = "lock" then
               if NumTokens /= 2 then
                  return;
               elsif NumTokens = 2 then
                  declare
                     T : String := Lines.To_String(Lines.Substring(S,Tokens(2).Start,Tokens(2).Start+Tokens(2).Length-1));
                  begin
                     if not PasswordManager.Is_PIN(T) then
                        return;
                     end if;
                     declare
                        P : PIN.PIN := PIN.From_String(T);
                     begin
                        if not PasswordManager.Locked(M) then
                           PasswordManager.Lock(M,P);
                        end if;
                     end;
                  end;
               end if;
            else
               return;
            end if;
         end;
      end;
   end loop;
end Main;
