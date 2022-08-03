# Short script to convert clock time to decimal time.
import pyperclip

# Define function to convert time and return a float
def ConvertToDecimal(Time_Input) -> float:
    Minutes = float(Time_Input)
    Dec_Minutes = Minutes / 60
    Dec_Minutes_Rounded = round(Dec_Minutes, 4)
    pyperclip.copy(Dec_Minutes_Rounded)
    return Dec_Minutes_Rounded


# Set up while loop
Loop_Status = True

while Loop_Status:
    # Get user input
    Time_Input = (input("Please enter time in minutes: "))

    print(f"Time in Decimal Format: {ConvertToDecimal(Time_Input)}")
    print("Time copied to clipboard")

    Answer = input("Type 'Y' to convert again: ")
    print(Answer)
    
    if Answer.upper() != 'Y':
        Loop_Status = False
    else:
        pass

