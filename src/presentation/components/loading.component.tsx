import { Box, styled } from '@mui/material';

const StyledLoadingContainer = styled(Box)({
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
  width: '100%',
  height: '100%',
  minHeight: '200px',
});

const StyledProgressWrapper = styled(Box)({
  width: '300px',
  padding: '4px',
  backgroundColor: 'transparent',
});

const StyledProgressBar = styled(Box)({
  height: '12px',
  width: '100%',
  display: 'flex',
  gap: '8px',
  alignItems: 'center',
});

const StyledSegment = styled(Box)<{ delay: number }>(({ delay }) => ({
  flex: 1,
  height: '100%',
  backgroundColor: '#ec4899',
  borderRadius: '2px',
  animation: 'blink 1.5s ease-in-out infinite',
  animationDelay: `${delay}s`,
  '@keyframes blink': {
    '0%, 100%': {
      opacity: 1,
    },
    '50%': {
      opacity: 0.2,
    },
  },
}));

export const LoadingComponent = () => {
  return (
    <StyledLoadingContainer>
      <StyledProgressWrapper>
        <StyledProgressBar>
          <StyledSegment delay={0} />
          <StyledSegment delay={0.15} />
          <StyledSegment delay={0.3} />
          <StyledSegment delay={0.45} />
          <StyledSegment delay={0.6} />
          <StyledSegment delay={0.75} />
          <StyledSegment delay={0.9} />
          <StyledSegment delay={1.05} />
        </StyledProgressBar>
      </StyledProgressWrapper>
    </StyledLoadingContainer>
  );
};
