for svc in account bank credit-card discovery-client gateway invoice log user; do
  echo "Testing $svc..."
  helm template "test-$svc" charts/banking-spring-boot -f "environments/staging/${svc}-values.yaml" > /dev/null
  if [ $? -eq 0 ]; then
    echo "✅ $svc: Render thành công"
  else
    echo "❌ $svc: Render THẤT BẠI"
  fi
done
