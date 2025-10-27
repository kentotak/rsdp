% Capitalizes the first letter of a string.
function myString = capitalize_first_letter(myString)
    myString = [upper(myString(1)), myString(2:end)];
end
