retry() {
  local retries=5
  local count=0
  local delay=3
  until "$@" 2>&1 | tee /tmp/cmd.log; do
    exit_code=$?
    count=$((count + 1))
    if grep -qE "ServiceUnavailable|connection refused|EOF" /tmp/cmd.log; then
      echo "Detected transient error, retrying..."
    else
      echo "Non-retryable error:"
      cat /tmp/cmd.log
      return $exit_code
    fi

    if [ "$count" -ge "$retries" ]; then
      echo "Command failed after $count attempts: $*"
      return $exit_code
    fi
    echo "Retry $count/$retries exited with code $exit_code. Retrying in $delay seconds..."
    sleep $delay
    delay=$((delay * 2))
  done
}

