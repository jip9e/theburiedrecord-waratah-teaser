K=~/Desktop/projects/knight-api/target/debug/kapi
D="Narrate as an older British documentary narrator: quiet, grave, unhurried, slightly hushed, never like a movie trailer. Speak this line slowly:"
i=0
while IFS= read -r L; do i=$((i+1)); n=$(printf %02d $i)
  [ -f "$n.wav" ] && continue
  for t in 1 2; do
    $K gen --model tts --param voice=Arlo --out "$PWD/j$n" --wait-s 200 "$D $L" > j$n.json 2>&1
    f=$(ls j$n/*/*.wav j$n/*.wav 2>/dev/null | head -1); [ -n "$f" ] && { cp "$f" $n.wav; break; }
  done
  echo "$n $( [ -f $n.wav ] && echo ok || echo FAIL)"
done <<'X'
Two hundred and eleven people.
A brand-new steamship.
And not one trace of them has ever been found.
July, nineteen-oh-nine. The Waratah leaves Durban, bound for Cape Town.
Next morning, a passing ship signals her by lamp.
Her reply is the last anyone will ever hear from her.
That night, the storm came.
Warships searched for weeks. The families paid for a search of their own.
The sea gave back nothing.
X
