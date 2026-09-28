# Activity 05 Counter — Test Log

**Student:** Adi Tauqir  
**Date:** September 28, 2026  
**Environment:** Flutter app running on the emulator  
**Overall result:** All required cases passed.

## Required Test Cases

| ID | Test case and steps | Expected result | Observed result | Status |
|---|---|---|---|---|
| T1 | Launch the app. | Counter starts at 40, increment starts at 7, history is empty, and the counter color is black. | The app opened with counter 40, increment 7, empty history, and black counter text. | Pass |
| T2 | Tap **Reset to 10**. | Counter changes to 10 and the counter becomes red. | Counter changed to 10 and displayed red text. | Pass |
| T3 | At 10, tap **Decrease**. | Counter remains 10 and minimum-limit feedback appears. | Counter stayed at 10 and displayed minimum-limit feedback. No invalid history entry was added. | Pass |
| T4 | Set the increment to 110 and tap **Increase** from 40. | Counter reaches the upper bound of 150. | Counter changed to 150. | Pass |
| T5 | At 150, tap **Increase** again. | Counter remains 150 and maximum-limit feedback appears. | Counter stayed at 150 and displayed maximum-limit feedback. | Pass |
| T6 | Set increment to 120 and tap **Increase** from 40. | The overshoot is rejected because the attempted value exceeds 150. | The counter remained 40 and the app reported the attempted value. | Pass |
| T7 | Clear the increment field and leave it blank. | Blank input is rejected and the previous valid increment remains active. | Blank input was rejected and the previous increment was retained. | Pass |
| T8 | Enter `-2` as the increment. | Negative input is rejected and the previous valid increment remains active. | `-2` was rejected and the previous increment was retained. | Pass |
| T9 | Enter `2.5` as the increment. | Decimal input is rejected and the previous valid increment remains active. | `2.5` was rejected with decimal-input feedback; the previous increment was retained. | Pass |
| T10 | Enter `hello` as the increment. | Nonnumeric input is rejected and the previous valid increment remains active. | `hello` was rejected and valid whole-number guidance was displayed. | Pass |
| T11 | Starting at 40, make three valid changes: 40 → 47 → 54 → 61. | Each valid change records the previous counter value in history. | The three valid changes were applied and prior values were recorded. | Pass |
| T12 | Press **Undo** three times after the undo-chain test. | Values restore in reverse order: 61 → 54 → 47 → 40. | Values restored to 54, then 47, then 40. | Pass |
| T13 | Press **Undo** once more when history is empty. | The app remains stable and provides harmless feedback. | The counter did not change and the app displayed no-earlier-value feedback. | Pass |
| T14 | Move the slider to another valid value. | The counter display and slider remain synchronized. | The counter updated to the slider value and remained synchronized. | Pass |
| T15 | Check the counter at 40. | Counter text is black for a normal value. | Counter text was black at 40. | Pass |
| T16 | Check the counter at 10. | Counter text is red at the minimum boundary. | Counter text was red at 10. | Pass |
| T17 | Set the counter above 90, such as 95. | Counter text is green above 90. | Counter text was green above 90. | Pass |
| T18 | Perform a valid counter change followed by an invalid boundary attempt. | The valid change appears in history; the invalid attempt does not. | Valid prior values appeared in history, while rejected attempts did not create history entries. | Pass |

## Screenshot Evidence

- `Q1-A Initial State.png` — initial value, increment, bounds, and empty history.
- `Q1-B Valid Change.png` — valid change and history entry.
- `Q1-C Rejected Boundary.png` — rejected maximum-boundary attempt and feedback.
- `Q1-D Undo.png` — undo restoring the prior state.
- `Q2-B Invalid Input.png` — invalid decimal input with prior increment retained.
- `Q2-C Feedback.png` — revised label, current step display, input guide, and improved invalid-input feedback after peer observation.

## Verification Summary

The Flutter widget tests passed, `flutter analyze` reported no issues, and the release APK built successfully.
